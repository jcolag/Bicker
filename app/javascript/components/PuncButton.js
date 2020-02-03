import React from "react";
import PropTypes from "prop-types";
import ReplyForm from "./ReplyForm";

class PuncButton extends React.Component {
  asMarkup(text) {
    return { __html: text };
  }
  
  render () {
    const html = this.asMarkup(this.props.punc);
    const name = `${this.props.pnumber}-${this.props.count}`;
    return (
      <React.Fragment>
        <a
          className='punctuation-button'
          href='javascript:void(0)'
          name={name}
          onClick={toggleReplyForm}
          title="Click to reply here"
        >
          <span
            name={name}
            dangerouslySetInnerHTML={ html }
          />
        </a>
        <ReplyForm
          count={ this.props.count }
          pnumber={ this.props.pnumber }
        />
      </React.Fragment>
    );
  }
}

PuncButton.propTypes = {
  count: PropTypes.number,
  pnumber: PropTypes.number,
  punc: PropTypes.string,
};
export default PuncButton
